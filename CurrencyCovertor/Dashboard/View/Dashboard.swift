//
//  ViewController.swift
//  CurrencyCovertor
//
//  Created by Admin on 08/08/22.
//

import UIKit
import CoreData

class Dashboard: UIViewController {

    @IBOutlet weak var collection_availableCurrencies: UICollectionView!
    @IBOutlet weak var tbl_currencyDropdown: UITableView!
    @IBOutlet weak var btn_currency: UIButton!
    @IBOutlet weak var txt_amount: TextFieldClass!
    var dropDownList = [String]()
    var dashboardVM = DashboardViewModel()
    var currencyRates = [String: Double]()
    var keysArray = [String]()
    var fixedConversionCurrency = ["AUD", "CAD", "CNH", "EUR", "GBP", "INR", "JPY", "NZD", "SGD", "THB", "USD"]
    let ACCEPTABLE_NUMBERS = "0123456789."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
        
    }

    //MARK: User defined methods
    func setupUI(){
        dropDownList = ["Male", "Female", "Other"]
        txt_amount.layer.borderColor = UIColor.lightGray.cgColor
        btn_currency.layer.borderColor = UIColor.lightGray.cgColor
        btn_currency.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btn_currency.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btn_currency.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btn_currency.configuration?.imagePadding = 20
        btn_currency.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.tbl_currencyDropdown.register(UINib(nibName: "CurrencyCell", bundle: nil), forCellReuseIdentifier: "CurrencyCell")
        self.tbl_currencyDropdown.isHidden = true
        self.tbl_currencyDropdown.layer.borderColor = UIColor.lightGray.cgColor
        self.tbl_currencyDropdown.separatorInset = .zero
        dashboardVM.dashboardDelegate = self
        dashboardVM.serviceCallToGetAPI()
        self.collection_availableCurrencies.register(UINib(nibName: "CurrencyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CurrencyCollectionViewCell")
    }
    
    @IBAction func btnCurrencyClicked(_ sender: Any) {
        if(txt_amount.text != ""){            
            self.tbl_currencyDropdown.isHidden = false
        }else{
            let alert = UIAlertController(title: "Alert", message: "Please enter amount", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

//MARK: Delegate of viewmodel
extension Dashboard : DashboardViewDelegate{
    func getUpdatesRateValues(rateValues: [String : Double]) {
        currencyRates = rateValues
        keysArray = Array(rateValues.keys)
        fixedConversionCurrency = keysArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        self.tbl_currencyDropdown.reloadData()
        self.collection_availableCurrencies.reloadData()
    }
    
    func getRateValues(rateValues: [String : Double]) {
        currencyRates = rateValues
        keysArray = Array(rateValues.keys)
        for i in 0...fixedConversionCurrency.count-1{
            keysArray = keysArray.filter {$0 != fixedConversionCurrency[i]}
        }
        keysArray = keysArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        fixedConversionCurrency += keysArray
        self.tbl_currencyDropdown.reloadData()
        self.collection_availableCurrencies.reloadData()
    }
}

//MARK: TableView methods
extension Dashboard : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fixedConversionCurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        cell.textLabel!.text = fixedConversionCurrency[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! CurrencyCell
        btn_currency.setTitle(currentCell.textLabel!.text, for: .normal)
        btn_currency.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        if(dashboardVM.currencies.contains(currentCell.textLabel!.text!)){
            dashboardVM.convertCurrency(enteredAmount: txt_amount.text ?? "1", selectedCurrency: currentCell.textLabel!.text ?? "USD")
        }else{
            let alert = UIAlertController(title: "SORRY..!!", message: "Only first 10 curreny converion from list is allowed", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.tbl_currencyDropdown.isHidden = true
    }
}

//MARK: Collectionview methods
extension Dashboard : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fixedConversionCurrency.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyCollectionViewCell", for: indexPath as IndexPath) as! CurrencyCollectionViewCell
        cell.lbl_currency.text = fixedConversionCurrency[indexPath.row]
        cell.lbl_amount.text = String(Double(round(10000 * (currencyRates[fixedConversionCurrency[indexPath.row]] ?? 0.0)) / 10000))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width/3)-30, height: CGFloat(80))
    }
}

//MARK: Textfield delegates
extension Dashboard: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == txt_amount){
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_NUMBERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            let countdots = (textField.text?.components(separatedBy: ".").count)! - 1
            if countdots > 0 && string == "."
            {
                return false
            }
            
            let numberOfDecimalDigits: Int
            if let dotIndex = textField.text!.firstIndex(of: ".") {
                numberOfDecimalDigits = (textField.text?.distance(from: dotIndex, to: textField.text!.endIndex))!-1
            } else {
                numberOfDecimalDigits = 0
            }
            
            if(numberOfDecimalDigits > 1){
                return false
            }
            return (string == filtered)
        }
        return true
    }
}


