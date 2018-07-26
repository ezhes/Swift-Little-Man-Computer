//
//  ViewController.swift
//  LMC
//
//  Created by Salman Husain on 9/6/17.
//  Copyright © 2017 Salman Husain. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet var codeText: NSTextView!
	@IBOutlet var outText: NSTextView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let machine = LMC()
        codeText.string = "        LDA FAKEINP\n        STA VALUE\n        LDA ONE\n        STA MULT\nOUTER   LDA ZERO\n        STA SUM\n        STA TIMES\nINNER   LDA SUM\n        ADD VALUE\n        STA SUM\n        LDA TIMES\n        ADD ONE\n        STA TIMES\n        SUB MULT\n        BRZ NEXT\n        BRA INNER\nNEXT    LDA SUM\n        OUT\n        LDA MULT\n        ADD ONE\n        STA MULT\n        SUB VALUE\n        BRZ OUTER\n        BRP DONE\n        BRA OUTER\nDONE    HLT\nVALUE   DAT 0 // Times table for\nMULT    DAT 0 // one input number\nSUM     DAT\nTIMES   DAT\nCOUNT   DAT\nZERO    DAT 000\nONE     DAT 001\nFAKEINP DAT 012"
        //Times table example for 12
        //machine.loadProgramIntoMemory(fromDecimal: [533, 326, 532, 327, 531, 328, 329, 528, 126, 328, 529, 132, 329, 227, 716, 607, 528, 902, 527, 132, 327, 226, 704, 825, 604, 000, 000, 000, 000, 000, 000, 000, 001, 012, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000])
		//Times table example for 12 unassembled
		//machine.assembleProgramIntoMemory(fromString: "        LDA FAKEINP\n        STA VALUE\n        LDA ONE\n        STA MULT\nOUTER   LDA ZERO\n        STA SUM\n        STA TIMES\nINNER   LDA SUM\n        ADD VALUE\n        STA SUM\n        LDA TIMES\n        ADD ONE\n        STA TIMES\n        SUB MULT\n        BRZ NEXT\n        BRA INNER\nNEXT    LDA SUM\n        OUT\n        LDA MULT\n        ADD ONE\n        STA MULT\n        SUB VALUE\n        BRZ OUTER\n        BRP DONE\n        BRA OUTER\nDONE    HLT\nVALUE   DAT 0 // Times table for\nMULT    DAT 0 // one input number\nSUM     DAT\nTIMES   DAT\nCOUNT   DAT\nZERO    DAT 000\nONE     DAT 001\nFAKEINP DAT 012")
		
        //machine.execute()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

	@IBAction func execute(_ sender: Any) {
		outText.string = ""
		//Create our VM
		let machine = LMC()
		//Set our output to our output view
		machine.printBlock = {
			toPrint in
			self.outText.string += "\(String(describing: toPrint))\n"
		}
		
		machine.getInputBlock = {
			let alert = NSAlert.init()
			alert.messageText = "Input requested"
			alert.addButton(withTitle: "Send")
			alert.addButton(withTitle: "Cancel")
			
			let textfield = NSTextField.init(frame: NSRect.init(x: 0, y: 0, width: 200, height: 24))
			textfield.stringValue = ""
			alert.accessoryView = textfield
			let result = alert.runModal()
			
			//Check if they hit ok
			if result == NSApplication.ModalResponse.alertFirstButtonReturn {
				if let value = Int(textfield.stringValue) {
					return value
				}else {
					machine.dPrint("[!!!] Invalid input recieved, failing to 0")
					return 0
				}
			}else {
				return 0
			}
		}
		//build
		machine.assembleProgramIntoMemory(fromString: codeText.string)

		//..and run!
		machine.execute()
	}
	
}

