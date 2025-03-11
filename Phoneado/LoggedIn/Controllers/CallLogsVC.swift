//
//  CallLogsVC.swift
//  Phoneado
//
//  Created by Shobhit Dhuria on 05/07/23.
//

import UIKit

class CallLogsVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRecordsLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    var callLog = [CallLogs]()
    var userId: String = ""
    var fromContactDetail: Bool = false
    var isLoadMore: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.register(UINib(nibName: "CallLogsTVC", bundle: nil), forCellReuseIdentifier: "CallLogsTVC")
        self.tableView.register(UINib(nibName: "UserCallLogsTVC", bundle: nil), forCellReuseIdentifier: "UserCallLogsTVC")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getCallLogs(offset: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = max(0.0, tableView.contentOffset.y)
        let visibleCells = tableView.visibleCells
        let topCell = visibleCells.first
        if topCell != nil
        {
            let indexPath = tableView.indexPath(for: topCell!)
            print("indexPath", indexPath)
            // point for the top visible content
            let pt: CGPoint = CGPoint(x: 0, y: y)
            print("pt", pt)
            // Access the bottom point using pt
            let bottomPoint = CGPoint(x: pt.x, y: pt.y + tableView.bounds.size.height)
            print("bottomPoint", bottomPoint)
            if self.isLoadMore
            {
                let idx = tableView.indexPathForRow(at: bottomPoint)
                print("idx", idx)
                print("self.callLog.count", self.callLog.count)
                if idx != nil
                {
                    if idx!.row == self.callLog.count - 1
                    {
                        self.isLoadMore = false
                        let offset = self.callLog.count
                        self.getCallLogs(offset: offset)
                    }
                }
            }
        }
    }
    
    func getCallLogs(offset: Int)
    {
        var param: [String: Any] = [:]
        
        if self.fromContactDetail
        {
            param.updateValue(self.userId, forKey: "userId")
        }
        Constant.appDelegate.showProgressHUD(view: self.view)
        LoggedInRequest().getCallLogs(fromContactVC: self.fromContactDetail ,offset: offset, params: param) { (response, error) in
            Constant.appDelegate.hideProgressHUD()
            if error == nil
            {
                print("response", response ?? [:])
                let res: [String: Any] = response!["data"] as! [String : Any]
                print("res", res)
                var calls: [CallLogs] = []
                let totalCount: Int = res["totalCount"] as! Int? ?? 0
                if let array: NSArray = res["callLogs"] as! NSArray?
                {
                    for post in array
                    {
                        if let dict: [String:Any] = post as! [String:Any]?
                        {
                            let call = CallLogs.init(dict)
                            calls.append(call)
                        }
                    }
                }
                
                if offset == 0
                {
                    self.callLog = calls
                }
                else
                {
                    self.callLog.append(contentsOf: calls)
                }
                
                if self.callLog.count > 0
                {
                    self.noRecordsLbl.isHidden = true
                }else
                {
                    self.noRecordsLbl.isHidden = false
                }
                self.isLoadMore = self.callLog.count < totalCount
                self.tableView.reloadData()
                print("self.calllog", self.callLog)
            }else
            {
                Alert().showAlertWithAction(title: "", message: error?.message ?? "Something went wrong, please try again later.", buttonTitle: "Ok", secondBtnTitle: "", withCallback: {}, withCancelCallback: {})
            }
        }
    }
    
    func getDate(date: Double) -> String
    {
        print("date", date)
        var predate = Date()
        let msgdate = date.dateFromTimeStamp().addingTimeInterval(0)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateToPrint: NSString = dateFormatter.string(from: msgdate ) as NSString
        let predateToPrint: NSString = dateFormatter.string(from: predate) as NSString
        
        print("dateToPrint", dateToPrint)
        print("predateToPrint", predateToPrint)
        if dateToPrint != predateToPrint {
            
            if Calendar.current.isDateInToday(dateFormatter.date(from: dateToPrint as String)!){
                return  "Today"
            }else if Calendar.current.isDateInYesterday(dateFormatter.date(from: dateToPrint as String)!){
                return  "Yesterday"
                
            }else if get_WeekDay(date: dateFormatter.date(from: dateToPrint as String)!){
                dateFormatter.dateFormat = "EEEE"
                return  dateFormatter.string(from: (date.dateFromTimeStamp()))
            }else{
                
                dateFormatter.dateFormat = "MM/dd/yy"
                return  dateFormatter.string(from: (date.dateFromTimeStamp()))
            }
        }else if dateToPrint == predateToPrint{
            return  "Today"
        }
            
        
        return "nil"
    }
    
    func getTime(date: Double) -> String
    {
        print("date", date)
        var predate = Date()
        let msgdate = date.dateFromTimeStamp().addingTimeInterval(0)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateToPrint: NSString = dateFormatter.string(from: msgdate ) as NSString
        let predateToPrint: NSString = dateFormatter.string(from: predate) as NSString
        
        print("dateToPrint", dateToPrint)
        print("predateToPrint", predateToPrint)
        if dateToPrint != predateToPrint {
            dateFormatter.dateFormat = " hh:mm a"
            let time = dateFormatter.string(from: (date.dateFromTimeStamp()))
            print("time", time)
            return  time
        }else if dateToPrint == predateToPrint{
            dateFormatter.dateFormat = " hh:mm a"
            let time = dateFormatter.string(from: (date.dateFromTimeStamp()))
            print("time", time)
            return time
        }
        
        return "nil"
    }
    
    func formatDuration(seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        
        guard let formattedString = formatter.string(from: seconds) else {
            return ""
        }
        
        return formattedString
    }
    
    func  get_WeekDay(date:Date) -> Bool {
        let currentComponent = Calendar.current.component(.weekOfYear, from: Date())
        
        let component = Calendar.current.component(.weekOfYear, from: date)
        if currentComponent == component || currentComponent == component+1 {
            if  currentComponent == component+1{
                if Calendar.current.component(.weekday, from: Date()) < Calendar.current.component(.weekday, from: date){
                    return true
                    
                }else{
                    return false
                    
                }
            }
            return true
        }else{
            return false
        }
        
    }

    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

extension CallLogsVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.callLog.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserCallLogsTVC") as! UserCallLogsTVC
        let calls = self.callLog[indexPath.row]
        cell.selectionStyle = .none
        
        let duration = Double(calls.duration ?? "0")
        print("duration", duration)
        let durationInSeconds: TimeInterval = duration ?? 0 // Example duration in seconds
        print("durationInSeconds", durationInSeconds)
        
        let formatDuration = formatDuration(seconds: durationInSeconds)
        print("formatDuration", formatDuration)
        
        if calls.direction == "outbound-dial"
        {
            cell.incomingOutgoingCallLbl.text = "Outgoing Call"
            cell.durationLbl.text = "\(formatDuration)"
        }else
        {
            
            if calls.status == "completed"
            {
                cell.incomingOutgoingCallLbl.text = "Incoming Call"
                cell.durationLbl.text = "\(formatDuration)"
            }else
            {
                cell.incomingOutgoingCallLbl.text = "Missed Call"
                cell.durationLbl.text = ""
            }
        }
        
        if calls.type == "voice"
        {
            cell.voiceVideoImageView.image = UIImage(named: "call1")
        }else
        {
            cell.voiceVideoImageView.image = UIImage(named: "video1")
        }
        cell.dateLbl.text = self.getDate(date: calls.dateCreated ?? 0)
        cell.timeLbl.text = self.getTime(date: calls.dateCreated ?? 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
