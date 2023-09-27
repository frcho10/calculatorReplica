//
//  homeViewController.swift
//  calculatorReplica
//
//  Created by Fernando Contreras González on 03/08/23.
//

import UIKit

class homeViewController: UIViewController {

    //MARK: - Outlets
    
    //result
    @IBOutlet weak var resultLabel: UILabel!
    
    //numbers
    @IBOutlet weak var number0: UIButton!
    @IBOutlet weak var number1: UIButton!
    @IBOutlet weak var number2: UIButton!
    @IBOutlet weak var number3: UIButton!
    @IBOutlet weak var number4: UIButton!
    @IBOutlet weak var number5: UIButton!
    @IBOutlet weak var number6: UIButton!
    @IBOutlet weak var number7: UIButton!
    @IBOutlet weak var number8: UIButton!
    @IBOutlet weak var number9: UIButton!
    @IBOutlet weak var numberDecimal: UIButton!
    
    //operator
    @IBOutlet weak var operatorAC: UIButton!
    @IBOutlet weak var operatorPlusMinus: UIButton!
    @IBOutlet weak var operatorPercent: UIButton!
    @IBOutlet weak var operatorResult: UIButton!
    @IBOutlet weak var operatorAddition: UIButton!
    @IBOutlet weak var operatorSubstraction: UIButton!
    @IBOutlet weak var operatorMultiplication: UIButton!
    @IBOutlet weak var operatorDivision: UIButton!
    
    
    //MARK: - Variables
    private var total: Double = 0
    private var temp: Double = 0
    private var pending: Double = 0 // value that is pending to add or substract
    private var operating = false
    private var decimal = false
    private var operation: OperationType = .none
    private var pendingOperation: OperationType = .none
    private var prevOperation: OperationType = .none
    private var equalWasSelected: Bool = true //for handle when operatorns must show the result or when they must await for a new number
    
    //MARK: - Constants
    private let kDecimalSeparator = Locale.current.decimalSeparator!
    private let kMaxLength = 9
    
    private enum OperationType{
        case none, addition, substraction, multiplication, divition, percent
    }
    
    private let auxFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        
        return formatter
    }()
    
    private let auxTotalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = ""
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        
        return formatter
    }()
    
    private let printFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = locale.groupingSeparator
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 9
        formatter.maximumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        
        return formatter
    }()
    
    private let printScientificFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 3
        formatter.exponentSymbol = "e"
        
        return formatter
    }()
    
    //MARK: - Initializer
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberDecimal.setTitle(kDecimalSeparator, for: .normal)//change title for decimal separator button

    }
    
    //MARK: - Button Actions
    
    @IBAction func operatorACAction(_ sender: UIButton) {
        
        clear()
        
        sender.shine()
    }
    @IBAction func operatorPlusMinusAction(_ sender: UIButton) {
        
        
        let valueInScreen = resultLabel.text!
        total = Double(valueInScreen.replacingOccurrences(of: ",", with: ""))! * (-1)
        
        resultLabel.text = printFormatter.string(from: NSNumber(value: total))
        
        sender.shine()
    }
    @IBAction func operatorPercentAction(_ sender: UIButton) {
        
        if prevOperation != .none {
            prevOperation = operation
        }
        
        operating = true
        decimal = false
        
        let auxOperation = operation
        let auxTemp = temp
        operation = .percent
        result()
        if prevOperation != .none{
            operation = prevOperation
            prevOperation = .percent
        }else{
            operation = auxOperation
            temp = auxTemp
        }
        
        sender.shine()
    }
    @IBAction func operatorResultCAction(_ sender: UIButton) {
        equalWasSelected = true
        result()
        operating = false
        prevOperation = .none
        sender.shine()
    }
    @IBAction func operatorAdditionAction(_ sender: UIButton) {
        
        if operation != .none && equalWasSelected == false {
            if (prevOperation == .multiplication || prevOperation == OperationType.divition) && (pending != 0) {
                equalWasSelected = true // flag to handle execute all result
            }
            result()
        }else{
            prevOperation = .addition
        }
        
        operating = true
        decimal = false
        operation = .addition
        
        operatorSubstraction.removeRound()
        operatorMultiplication.removeRound()
        operatorDivision.removeRound()
        sender.round()
    }
    @IBAction func operatorSubstractionAction(_ sender: UIButton) {
        
        if operation != .none && equalWasSelected == false {
            if (prevOperation == .multiplication || prevOperation == OperationType.divition) && (pending != 0) {
                equalWasSelected = true // flag to handle execute all result
            }
            result()
        }else{
            prevOperation = .substraction
        }
        
        operating = true
        decimal = false
        operation = .substraction
        
        operatorAddition.removeRound()
        operatorMultiplication.removeRound()
        operatorDivision.removeRound()
        sender.round()
    }
    @IBAction func operatorMultiplicationAction(_ sender: UIButton) {
        
        if operation != .none && equalWasSelected == false {
            
            if (prevOperation == .addition || prevOperation == OperationType.substraction) && (pending == 0) {
                
                pending = total // total is anterior value in screen before new number typed
                pendingOperation = prevOperation
            }else{
                //aqui hace falta guardar el pendingOperation
                prevOperation = .multiplication
                result()
            }
        }else{
            if prevOperation == .addition {
                total = total - temp
                resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
                
                pending = total // total is anterior value in screen before new number typed
                pendingOperation = prevOperation
            }else if prevOperation == .substraction {
                total = total + temp
                resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
                
                pending = total // total is anterior value in screen before new number typed
                pendingOperation = prevOperation
            }else{
                
            }
            prevOperation = .multiplication
        }
        
        operating = true
        decimal = false
        operation = .multiplication
        
        operatorAddition.removeRound()
        operatorSubstraction.removeRound()
        operatorDivision.removeRound()
        sender.round()
    }
    @IBAction func operatorDivisionction(_ sender: UIButton) {
        
        if operation != .none && equalWasSelected == false {
            
            if (prevOperation == .addition || prevOperation == OperationType.substraction) && (pending == 0) {
                
                pending = total // total is anterior value in screen before new number typed
                pendingOperation = prevOperation
            }else{
                //aqui hace falta guardar el pendingOperation
                prevOperation = .divition
                result()
            }
        }else{
            if prevOperation == .addition {
                total = total - temp
                resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
                
                pending = total // total is anterior value in screen before new number typed
                pendingOperation = prevOperation
            }else if prevOperation == .substraction {
                total = total + temp
                resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
                
                pending = total // total is anterior value in screen before new number typed
                pendingOperation = prevOperation
            }else{
                
            }
            prevOperation = .multiplication
        }
        
        operating = true
        decimal = false
        operation = .divition
        
        operatorAddition.removeRound()
        operatorSubstraction.removeRound()
        operatorMultiplication.removeRound()
        sender.round()
    }
    

    @IBAction func numberDecimalAction(_ sender: UIButton) {
        
        let currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if !operating && currentTemp.count >= kMaxLength {
            return
        }
        if !resultLabel.text!.contains(".") {
            resultLabel.text = resultLabel.text! + kDecimalSeparator
        }
        decimal = true
        
        sender.shine()
    }
    @IBAction func numberAction(_ sender: UIButton) {
        //CAMBIAR LOGICA PARA QUE EL CURRENT TEMP SEA EL LABEL Y TEMP PERMANEZCA SIENDOO TEMP
        var currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if( (operating == true || equalWasSelected) && decimal != true ){
            
            operatorAC.setTitle("C", for: .normal)
            
            if !operating && currentTemp.count >= kMaxLength {
                return
            }
            
            //Number selected is printed in screen
            let number = sender.tag
            //temp = Double(String(number) )!
            
            if operating {
                    let valueInScreen = resultLabel.text!
                    total = Double(valueInScreen.replacingOccurrences(of: ",", with: ""))!
                    temp = Double(number)
                operating = false
            }else{
                if resultLabel.text!.contains("-0") {
                    total = Double(number) * -1
                    resultLabel.text = printFormatter.string(from: NSNumber(value: total))
                    
                    return
                }else{
                    total = 0
                    temp = Double(number)
                }
            }
            resultLabel.text = printFormatter.string(from: NSNumber(value: number))
        }else{
            
            if !operating && currentTemp.count >= kMaxLength {
                return
            }
            
            let valueInScreen = resultLabel.text!
            let number = sender.tag
            let concat = valueInScreen.replacingOccurrences(of: ",", with: "") + String(number)
            temp = Double(concat)!
            //temp = Double(String(number) )!
            if decimal {
                resultLabel.text = concat
            }else{
                resultLabel.text = printFormatter.string(from: NSNumber(value: Double(concat)!))
            }
        }
        
        equalWasSelected = false
        
        
        
        //decimal is selected
        if decimal {
            currentTemp = "\(currentTemp)\(kDecimalSeparator)"
            
        }
        
        
        
        sender.shine()
    }
    
    
    //clean values
    private func clear() {
        let banderaEtiqueta: String? = operatorAC.titleLabel?.text!
        if !banderaEtiqueta!.contains("AC") && (operation != .none || prevOperation == .percent ) {//it validate that temp is not empty and C button hasn`t been pressed
            if total == 0 && !equalWasSelected {
                total = temp
                temp = 0
            }else {
                total = 0
            }
            resultLabel.text = "0"
            operatorAC.setTitle("AC", for: .normal)
            
        }else {
            temp = 0
            total = 0
            resultLabel.text = "0"
            operatorAC.setTitle("AC", for: .normal)
            operation = OperationType.none
            prevOperation = .none
            operating = false
            equalWasSelected = true
            
            operatorAddition.removeRound()
            operatorSubstraction.removeRound()
            operatorMultiplication.removeRound()
            operatorDivision.removeRound()
        }
    }
    
    //obtains final result
    private func result() {
        
        switch operation {
        case .none:
            //do nothing
            return
        case .addition:
            if prevOperation == .percent {
                let numberPercent = (total*100)/temp
                let auxTotal = total
                total = total + numberPercent
                temp = auxTotal
            }else{
                total = total + temp
            }
            break
        case .substraction:
            if prevOperation == .percent {
                let numberPercent = (total*100)/temp
                let auxTotal = total
                total = total - numberPercent
                temp = auxTotal
            }else{
                total = total - temp
            }
            break
        case .multiplication:
            if (prevOperation == .addition || prevOperation == OperationType.substraction) && (pending != 0) {
                if prevOperation == .addition{
                    total = (total * temp) + pending
                }else{
                    total = (total * temp) - pending
                }
                pending = 0.0
                pendingOperation = .none
            }else{
                if equalWasSelected == false || (pendingOperation != . none && pending == 0) {
                    total = total * temp
                }else if prevOperation == .percent{
                    let auxTotal = total
                    total = total * temp
                    temp = auxTotal
                    
                }else{
                    if pendingOperation == .addition{
                        total = (total * temp) + pending
                    }else{
                        total = (total * temp) - pending
                    }
                    pending = 0.0
                    pendingOperation = .none
                }
            }
            break
        case .divition:
            if (prevOperation == .addition || prevOperation == OperationType.substraction) && (pending != 0) {
                if prevOperation == .addition{
                    total = (total / temp) + pending
                }else{
                    total = (total / temp) - pending
                }
                pending = 0.0
                pendingOperation = .none
            }else{
                if equalWasSelected == false || (pendingOperation != . none && pending == 0) {
                    total = total / temp
                }else if prevOperation == .percent{
                    let auxTotal = total
                    total = total / temp
                    temp = auxTotal
                    
                }else{
                    if pendingOperation == .addition{
                        total = (total / temp) + pending
                    }else{
                        total = (total / temp) - pending
                    }
                    pending = 0.0
                    pendingOperation = .none
                }
            }
            break
        case .percent:
            //temp = temp / 100 bad operation
            if (prevOperation == .addition || prevOperation == .substraction) && !equalWasSelected {
                
                let valueTemp = (total * (temp/100))
                total = valueTemp
            }else{
                let valueInScreen = resultLabel.text!
                temp = total
                total = Double(valueInScreen.replacingOccurrences(of: ",", with: ""))!
                
                total = total / 100
            }
           
            break
        }
        
        if let currentTotal = auxTotalFormatter.string(from: NSNumber(value: total)), currentTotal.count > kMaxLength {
            resultLabel.text = printScientificFormatter.string(from: NSNumber(value: total))
        }else {
            resultLabel.text = printFormatter.string(from: NSNumber(value: total))
        }
        
        operatorAddition.removeRound()
        operatorSubstraction.removeRound()
        operatorMultiplication.removeRound()
        operatorDivision.removeRound()
        
        equalWasSelected = true
        
        
    }
    
    
}
